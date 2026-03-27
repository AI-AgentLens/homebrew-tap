cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.124"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.124/agentshield_0.2.124_darwin_amd64.tar.gz"
      sha256 "c5ac9e486e906bf3cad989687869dafb43378069cec6662850b2a7a92743c02b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.124/agentshield_0.2.124_darwin_arm64.tar.gz"
      sha256 "271cb1a406af42d270d934187d8db4b9eef4a3da652d7b3110fc5af335b8d330"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.124/agentshield_0.2.124_linux_amd64.tar.gz"
      sha256 "3b1aa8c425cc9e7cb6883591476a44bb1ab877e6d6685bcd759f2cdb45d056e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.124/agentshield_0.2.124_linux_arm64.tar.gz"
      sha256 "f604f17b8ca7db786b3a2d603d4e978096713226cb39da3f792a396d27ce09e8"
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
