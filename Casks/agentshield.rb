cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1857"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1857/agentshield_0.2.1857_darwin_amd64.tar.gz"
      sha256 "80b8349be9538d4690569602a84d0fc9ac618353f10415f6e4a755bd97f77a32"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1857/agentshield_0.2.1857_darwin_arm64.tar.gz"
      sha256 "097332428f06619001e66a2b630dfca36408081b17b7fbe0210b3a655795decc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1857/agentshield_0.2.1857_linux_amd64.tar.gz"
      sha256 "875f7dbd67f5bade48b942e1639b60671988499a832da54b2c3173ab7dd3260e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1857/agentshield_0.2.1857_linux_arm64.tar.gz"
      sha256 "3c3b5c61b32b3df1257f8696f904f56e05a6b45124c0d2665f8e8d972d85b2a5"
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
