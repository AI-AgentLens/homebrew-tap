cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2048"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2048/agentshield_0.2.2048_darwin_amd64.tar.gz"
      sha256 "ba4b38827c0bee6fd82943a0786f4bc9a755fc9e51e8ab8794c97f5d0ea87197"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2048/agentshield_0.2.2048_darwin_arm64.tar.gz"
      sha256 "80322435bf317e8d46cabcf0efcd9bf6b00c74e2912ae563ce7f7327d8426e4f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2048/agentshield_0.2.2048_linux_amd64.tar.gz"
      sha256 "ffb49e9b10741475fe95ea85c07ed36a168647ef982d7d79cabf963cc6bd2976"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2048/agentshield_0.2.2048_linux_arm64.tar.gz"
      sha256 "0c9da429056a55c1e0786a8cd4c710df55e1d38e41edef544d7e3071f9c73390"
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
