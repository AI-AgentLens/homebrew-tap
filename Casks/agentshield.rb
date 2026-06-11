cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1286"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1286/agentshield_0.2.1286_darwin_amd64.tar.gz"
      sha256 "94e5c16d8f273a1688985e66425a80fdbd4db9bf8075e43fbea83732d8cfb008"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1286/agentshield_0.2.1286_darwin_arm64.tar.gz"
      sha256 "ca1d6d3aaccba4bada221ac7e423ceacd80ba49859f51f7480b3bc0886577cbf"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1286/agentshield_0.2.1286_linux_amd64.tar.gz"
      sha256 "7461bebf9868935ff3aedd2d10e8a7a75b07c7e1c57de8efa5453d355b66fa38"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1286/agentshield_0.2.1286_linux_arm64.tar.gz"
      sha256 "47dc0adf5118e8c29591ccadb96b1428dea125aecfeda7f63e0b3a19826371c2"
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
