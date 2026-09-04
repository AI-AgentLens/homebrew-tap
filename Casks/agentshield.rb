cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2043"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2043/agentshield_0.2.2043_darwin_amd64.tar.gz"
      sha256 "b6b1075e07830efb96bf17f41ac5ad3bbd03f2b8a7b987413fdac56d1c0b7737"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2043/agentshield_0.2.2043_darwin_arm64.tar.gz"
      sha256 "0638d73f61997364e5c86c03e1d2abd940da249e4e6e3d663b1d1370535ef25e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2043/agentshield_0.2.2043_linux_amd64.tar.gz"
      sha256 "aa08c5b75e9b53e5a4641976d123081596d52e3f7838e0e1de41baa83f7beb9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2043/agentshield_0.2.2043_linux_arm64.tar.gz"
      sha256 "32044a335ef9f0a489fc0ec29bec24db719d796e3530085d53fc2b92b0afd488"
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
