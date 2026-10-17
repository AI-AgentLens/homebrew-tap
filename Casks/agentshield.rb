cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2452"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2452/agentshield_0.2.2452_darwin_amd64.tar.gz"
      sha256 "152beea3471edfdf34805421c7e4da28e6b84326229879f56514e2e029a32a76"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2452/agentshield_0.2.2452_darwin_arm64.tar.gz"
      sha256 "05d422a19f9714b9e1a9e9cec4845a396cc0df18cb1a2b1b91c4a63c4c9e2466"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2452/agentshield_0.2.2452_linux_amd64.tar.gz"
      sha256 "ae531da07a77cb29893905cb7ab2be6ade0fc26f2415ad4c8048a81e722aca0b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2452/agentshield_0.2.2452_linux_arm64.tar.gz"
      sha256 "cd390ad5d8053367d5e04a04179313c6ed7c405bebf610fb38e229e440e3c8b9"
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
