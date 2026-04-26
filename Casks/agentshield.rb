cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.747"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.747/agentshield_0.2.747_darwin_amd64.tar.gz"
      sha256 "261f19b366564a125154b8850906b92a3fd6997a751e90501c4e2b2ec1575ed8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.747/agentshield_0.2.747_darwin_arm64.tar.gz"
      sha256 "22a3e2d9989708f3e60b2dd4d3def0e00ac502bd784762b20ed048101fce9097"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.747/agentshield_0.2.747_linux_amd64.tar.gz"
      sha256 "19f1ce80daf3aa7343822d056a1ba6e33214c315f3248f26edee28b5c685f8bd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.747/agentshield_0.2.747_linux_arm64.tar.gz"
      sha256 "218ee8bf838355db5e67681701e78e107bbcbf651849599aa301389403c3e04a"
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
