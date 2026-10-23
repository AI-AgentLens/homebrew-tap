cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2507"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2507/agentshield_0.2.2507_darwin_amd64.tar.gz"
      sha256 "0a00cf227c9af7b9a3a2722d2ac86f43e7d869c8ca048f7d0e7d3ecef0138459"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2507/agentshield_0.2.2507_darwin_arm64.tar.gz"
      sha256 "5cd1ff0fd47ddc451efe5c8acdaf20da8d9522dfe2bf0a27a9a23c546a71f45b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2507/agentshield_0.2.2507_linux_amd64.tar.gz"
      sha256 "fdd9e5ea8ac487084a03e0ebc7f616f0c8c2d8f75898419b42d2f4c23237a9a1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2507/agentshield_0.2.2507_linux_arm64.tar.gz"
      sha256 "ba8527eb02f609b443926d16b13ae9a85784cfacc26954e9df91a016d2556351"
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
