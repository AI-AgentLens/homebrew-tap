cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.471"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.471/agentshield_0.2.471_darwin_amd64.tar.gz"
      sha256 "ab7bf7982e7ffa8e98b665faaf42c185ef6b3ecdf2360c9fb19ab38747fd725b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.471/agentshield_0.2.471_darwin_arm64.tar.gz"
      sha256 "97941659a0dbc4de82f437a43887057c46d2d965a8fa03df58d391c22b167402"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.471/agentshield_0.2.471_linux_amd64.tar.gz"
      sha256 "838d6405f1de6461397b75d22518d9c111f32df1a7df3dad4e399328c9193f29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.471/agentshield_0.2.471_linux_arm64.tar.gz"
      sha256 "4fff88827e120a921c3fc384843ef7c4d4b839f0f8a0002afb67cbaf8fe1820b"
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
