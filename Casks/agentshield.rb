cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.994"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.994/agentshield_0.2.994_darwin_amd64.tar.gz"
      sha256 "13cbb5626135c0c821c150cbf774a7295456ea2a3465bea5d59c67b5a3603fe8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.994/agentshield_0.2.994_darwin_arm64.tar.gz"
      sha256 "53ac4b5fa73ab70fbb9c5f206b0dfdb286623cdd3b30fd029cd018c19508fa9a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.994/agentshield_0.2.994_linux_amd64.tar.gz"
      sha256 "062e88b39b810eda67c816367c6f883363eabe7f5085bd4d0ba8db8408d60128"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.994/agentshield_0.2.994_linux_arm64.tar.gz"
      sha256 "35da041a35d58ff203614e0e7d5f9ca133cb3ebc5d63b9b9666fbc1ab1180fde"
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
