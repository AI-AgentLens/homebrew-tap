cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2171"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2171/agentshield_0.2.2171_darwin_amd64.tar.gz"
      sha256 "7a91224b24966311b852a72c66b9a493d1db999e51ef6aad5195ab04c2ba644d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2171/agentshield_0.2.2171_darwin_arm64.tar.gz"
      sha256 "4b6af7ed91866e50dee80134ef2672d56f2345494fd90404a01ebbb20bc3d369"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2171/agentshield_0.2.2171_linux_amd64.tar.gz"
      sha256 "c2200af8a96211c584ad8b0b307e33c22a784ac55db1e31a04a0b3a19cbf66e2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2171/agentshield_0.2.2171_linux_arm64.tar.gz"
      sha256 "395cbaeaabbdb426caf8a69d2f2d94716b02ee98c0590d9662d1b1e7f99b880c"
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
