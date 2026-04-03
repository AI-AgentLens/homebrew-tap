cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.350"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.350/agentshield_0.2.350_darwin_amd64.tar.gz"
      sha256 "29459b83c431e77604f07aade00c59716f47ba0ef85fa9e406cee00709110df8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.350/agentshield_0.2.350_darwin_arm64.tar.gz"
      sha256 "756a65f8d0722a2dcfa2ee3f8f2492e2a21c97613bfd0ecf895f0b66dc763d28"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.350/agentshield_0.2.350_linux_amd64.tar.gz"
      sha256 "bfe1da3ae754cc92b49cc367993a0e81511003355780015dc74ec27d7a32fc51"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.350/agentshield_0.2.350_linux_arm64.tar.gz"
      sha256 "9ece30b65f53a42a4b084afe03d13e3a2dc316991b509899ae38cfaadecb2fb2"
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
