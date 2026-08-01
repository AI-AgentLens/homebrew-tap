cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1767"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1767/agentshield_0.2.1767_darwin_amd64.tar.gz"
      sha256 "920096b1e4f965f910712bd0b23e51a414c81796077084117d8ca0bcf7664bdf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1767/agentshield_0.2.1767_darwin_arm64.tar.gz"
      sha256 "d940a823c4d7f491b4fbb186d3e5e1097e01001c61cdbe5d78ff4dd1c8ea2163"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1767/agentshield_0.2.1767_linux_amd64.tar.gz"
      sha256 "351484434d9f1ae3efab8502173fd788b09fa8e9b6db406a31c763920e3330ab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1767/agentshield_0.2.1767_linux_arm64.tar.gz"
      sha256 "6919b1fa147672e39ce08cfe9c0bdd3e0f6c031873188967ce501863fafeb83a"
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
