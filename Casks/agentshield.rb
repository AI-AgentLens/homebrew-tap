cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.552"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.552/agentshield_0.2.552_darwin_amd64.tar.gz"
      sha256 "0fd892cb1b8f3e6bea7c78638c45440f1dc4138a33c565077a5e9a536cbd3d83"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.552/agentshield_0.2.552_darwin_arm64.tar.gz"
      sha256 "81d7f9f379c0364dd23cc2b268736135cb05cacaacc83fc44110779683dfc15c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.552/agentshield_0.2.552_linux_amd64.tar.gz"
      sha256 "260d487e4a922bf5c7dd0ae42d6cbdb526b58653e882a480a0d6564f841849a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.552/agentshield_0.2.552_linux_arm64.tar.gz"
      sha256 "62fae5ff9a66c70f4b1819a2dbf4b7a811f90477e7c1dce6565f60d8df88b7b0"
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
