cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.773"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.773/agentshield_0.2.773_darwin_amd64.tar.gz"
      sha256 "b0fcbb2dcfe859ac461c15f9e9c2dee5b5f43c1836f8e8507d5ec39d4f56e11b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.773/agentshield_0.2.773_darwin_arm64.tar.gz"
      sha256 "c55662c3f572b35b580dbecb5e3824b896c4c7533df1ccc7052679a462750205"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.773/agentshield_0.2.773_linux_amd64.tar.gz"
      sha256 "8c38b558bb05296a30732a1b61bd56d6a14513d732b44284b5c0ab7afff06010"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.773/agentshield_0.2.773_linux_arm64.tar.gz"
      sha256 "22e3fca6cbe0177355d39adc003af759e90277bdde43c82e4c747c57c3c83362"
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
