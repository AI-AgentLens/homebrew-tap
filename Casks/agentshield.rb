cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1243"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1243/agentshield_0.2.1243_darwin_amd64.tar.gz"
      sha256 "60adbd96e8ccc84c27784dfbf6ad77212dc3fe4fd1be5881ca7cc219359c565d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1243/agentshield_0.2.1243_darwin_arm64.tar.gz"
      sha256 "891d8af9cafff21ca17d76fd21666cb694072fc35e3dbfa2087b59b31b48c40d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1243/agentshield_0.2.1243_linux_amd64.tar.gz"
      sha256 "092cd1e3a9fb018814a3d78d16642d663b0f908079bb76ca13efc584efdd7c59"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1243/agentshield_0.2.1243_linux_arm64.tar.gz"
      sha256 "7963905b23fb3b5f4a30cf973bb8f9396278377c67c5ac496065c0c9557f34b0"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
