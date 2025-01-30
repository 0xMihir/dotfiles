#!/usr/bin/env python3
import subprocess
import json
import xml.etree.ElementTree as ET

# nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,nounits,noheader
def format_memory(memory_used_mib):
    """Format memory usage from MiB to a more readable format."""
    memory_used_mb = memory_used_mib * 1.049
    memory_used_gb = memory_used_mib / 953.84
    # memory_total_gb = float(memory_total) / 1000
    if memory_used_gb < 1:
        return f"{memory_used_mb:.2f} MB"
    else:
        return f"{memory_used_gb:.2f} GB"

def get_gpu_info():
    try:
        # Run the nvidia-smi command to get GPU utilization and memory usage
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=utilization.gpu,memory.used,memory.total',
             '--format=csv,nounits,noheader'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
       
        # Split the output into lines and then split each line by comma to get individual values
        gpu_info = [line.split(',') for line in result.stdout.strip().split('\n')]
        return gpu_info
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e.stderr}")
        return None

def get_gpu_processes():
    try:
        # Run the nvidia-smi command to get GPU processes
        result = subprocess.run(
            ['nvidia-smi', '-q', '-x'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        # Split the output into lines and then split each line by comma to get individual values
        # gpu_processes = [line.split(',') for line in result.stdout.strip().split('\n')]
        tree = ET.ElementTree(ET.fromstring(result.stdout))
        root = tree.getroot()
        gpu_processes = []
        for gpu in root.findall('.//gpu'):
            processes = gpu.find('processes')
            if processes is not None:
                for process in processes.findall('process_info'):
                    pid = process.find('pid').text
                    used_memory = process.find('used_memory').text.split()[0]
                    name = process.find('process_name').text
                    gpu_processes.append((pid, used_memory, name))
        return gpu_processes
    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e.stderr}")
        return None
    
def format_gpu_processes(processes):
    formatted_processes = ""
    for pid, used_memory, name in processes:
        used_memory = format_memory(float(used_memory))
        formatted_processes += f"PID: {pid}, Memory: {used_memory}, Name: {name}\n"
    return formatted_processes

if __name__ == "__main__":
    info = get_gpu_info()
    if info:
        for i, details in enumerate(info):
            util, used_mem, total_mem = details
            formatted_memory = format_memory(float(used_mem))
            text = f"{util}% {formatted_memory}"
            cl = "normal"
            usage_percentage = float(used_mem) / float(total_mem)
            if usage_percentage > 0.9:
                cl = "critical"
            elif usage_percentage > 0.75:
                cl = "warning"
                
            data = {"class": cl, "text": text, "tooltip": format_gpu_processes(get_gpu_processes())}
            print(json.dumps(data))
            if i == 0:  # Assuming we only want the first GPU's info
                break
            
    else:
        print("Failed to retrieve GPU information.")
